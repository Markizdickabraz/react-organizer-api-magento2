<?php

namespace Vendor\Todo\Model\Resolver;

use Magento\Framework\GraphQl\Query\ResolverInterface;
use Magento\Framework\GraphQl\Schema\Type\ResolveInfo;
use Magento\Framework\Exception\LocalizedException;
use Vendor\Todo\Model\ResourceModel\Task\CollectionFactory;
use Magento\Customer\Model\Session as CustomerSession;

class GetCustomerTodos implements ResolverInterface
{
    protected $collectionFactory;
    protected $customerSession;

    public function __construct(
        CollectionFactory $collectionFactory,
        CustomerSession   $customerSession
    )
    {
        $this->collectionFactory = $collectionFactory;
        $this->customerSession = $customerSession;
    }

    public function resolve(
        $field,
        $context,
        ResolveInfo $info,
        array $value = null,
        array $args = null
    )
    {
        if (!$context->getUserId()) {
            throw new LocalizedException(__('User is not authorized'));
        }

        $customerId = $context->getUserId();

        $tasks = $this->collectionFactory->create()
            ->addFieldToFilter('customer_id', $customerId)
            ->setOrder('date', 'DESC');

        $result = [];
        foreach ($tasks as $task) {
            $result[] = [
                'id' => $task->getTaskId(),
                'title' => $task->getTitle(),
                'text' => $task->getText(),
                'date' => $task->getDate(),
                'status' => $task->getStatus(),
            ];
        }

        return $result;
    }
}
